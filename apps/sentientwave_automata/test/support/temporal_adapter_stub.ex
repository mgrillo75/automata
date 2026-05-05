defmodule SentientwaveAutomata.TestSupport.TemporalAdapterStub do
  @behaviour SentientwaveAutomata.Adapters.Temporal.Behaviour

  alias SentientwaveAutomata.Governance.LawProposal
  alias SentientwaveAutomata.Governance.ProposalActivities
  alias SentientwaveAutomata.Repo

  @impl true
  def start_workflow("governance_proposal_workflow", input, opts) when is_map(input) do
    workflow_id = Keyword.fetch!(opts, :workflow_id)

    if Map.get(input, "mode", "open") == "open" do
      _ =
        ProposalActivities.execute(nil, [
          %{
            "step" => "open_proposal",
            "workflow_id" => workflow_id,
            "command" => Map.get(input, "command", %{})
          }
        ])
    end

    {:ok, %{workflow_id: workflow_id, run_id: unique_run_id(), status: :running}}
  end

  def start_workflow(_workflow_name, input, opts) when is_map(input) do
    workflow_id = Keyword.get(opts, :workflow_id, Map.get(input, :workflow_id, "test-workflow"))

    {:ok,
     %{
       workflow_id: workflow_id,
       run_id: unique_run_id(),
       status: :running
     }}
  end

  @impl true
  def signal_workflow(workflow_id, "vote", payload) do
    case Repo.get_by(LawProposal, workflow_id: workflow_id) do
      %LawProposal{} = proposal ->
        _ =
          ProposalActivities.execute(nil, [
            %{"step" => "record_vote", "proposal_id" => proposal.id, "command" => payload}
          ])

        :ok

      nil ->
        {:error, :not_found}
    end
  end

  def signal_workflow(workflow_id, "resolve", _payload) do
    case Repo.get_by(LawProposal, workflow_id: workflow_id) do
      %LawProposal{} = proposal ->
        _ =
          ProposalActivities.execute(nil, [
            %{"step" => "resolve_proposal", "proposal_id" => proposal.id}
          ])

        :ok

      nil ->
        {:error, :not_found}
    end
  end

  def signal_workflow(_workflow_id, _signal, _payload), do: :ok

  @impl true
  def query_workflow(workflow_id),
    do: {:ok, %{"workflow_id" => workflow_id, "status" => "running"}}

  @impl true
  def start_agent_run(input) when is_map(input) do
    workflow_id = Map.get(input, :workflow_id, Map.get(input, "workflow_id", "test-agent-run"))

    {:ok,
     %{
       workflow_id: workflow_id,
       run_id: unique_run_id(),
       status: :running
     }}
  end

  @impl true
  def signal_agent_run(_workflow_id, _payload), do: :ok

  @impl true
  def query_agent_run(workflow_id),
    do: {:ok, %{"workflow_id" => workflow_id, "status" => "running"}}

  defp unique_run_id, do: "test-run-#{System.unique_integer([:positive])}"
end
