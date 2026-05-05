defmodule SentientwaveAutomata.Settings.FederationConfig do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "federation_configs" do
    field :singleton_key, :string, default: "default"
    field :enabled, :boolean, default: false
    field :server_name, :string, default: "localhost"
    field :public_base_url, :string
    field :delegation_enabled, :boolean, default: true
    field :delegation_target, :string
    field :allowlist_enabled, :boolean, default: false
    field :allowlist_domains, {:array, :string}, default: []
    field :profile_lookup_enabled, :boolean, default: true
    field :media_federation_enabled, :boolean, default: true
    field :notes, :string
    field :metadata, :map, default: %{}

    timestamps(type: :utc_datetime_usec)
  end

  def changeset(config, attrs) do
    config
    |> cast(attrs, [
      :singleton_key,
      :enabled,
      :server_name,
      :public_base_url,
      :delegation_enabled,
      :delegation_target,
      :allowlist_enabled,
      :allowlist_domains,
      :profile_lookup_enabled,
      :media_federation_enabled,
      :notes,
      :metadata
    ])
    |> put_default_singleton()
    |> normalize_string(:server_name)
    |> normalize_string(:public_base_url)
    |> normalize_string(:delegation_target)
    |> normalize_string(:notes)
    |> validate_required([:singleton_key, :server_name])
    |> validate_length(:server_name, min: 1, max: 255)
    |> validate_length(:public_base_url, max: 500)
    |> validate_length(:delegation_target, max: 255)
    |> validate_length(:notes, max: 2_000)
    |> validate_format(:server_name, ~r/^[A-Za-z0-9.-]+(:[0-9]+)?$/,
      message: "must be a Matrix server name"
    )
    |> validate_delegation_target()
    |> unique_constraint(:singleton_key)
  end

  defp put_default_singleton(changeset) do
    case get_field(changeset, :singleton_key) do
      nil -> put_change(changeset, :singleton_key, "default")
      "" -> put_change(changeset, :singleton_key, "default")
      _ -> changeset
    end
  end

  defp normalize_string(changeset, field) do
    update_change(changeset, field, fn value ->
      value
      |> to_string()
      |> String.trim()
    end)
  end

  defp validate_delegation_target(changeset) do
    if get_field(changeset, :enabled) && get_field(changeset, :delegation_enabled) do
      changeset
      |> validate_required([:delegation_target])
      |> validate_format(:delegation_target, ~r/^[A-Za-z0-9.-]+:[0-9]+$/,
        message: "must include host and port"
      )
    else
      changeset
    end
  end
end
