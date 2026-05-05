defmodule SentientwaveAutomata.Repo.Migrations.CreateFederationConfigs do
  use Ecto.Migration

  def change do
    create table(:federation_configs, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :singleton_key, :string, null: false, default: "default"
      add :enabled, :boolean, null: false, default: false
      add :server_name, :string, null: false
      add :public_base_url, :string
      add :delegation_enabled, :boolean, null: false, default: true
      add :delegation_target, :string
      add :allowlist_enabled, :boolean, null: false, default: false
      add :allowlist_domains, {:array, :string}, null: false, default: []
      add :profile_lookup_enabled, :boolean, null: false, default: true
      add :media_federation_enabled, :boolean, null: false, default: true
      add :notes, :text
      add :metadata, :map, null: false, default: %{}

      timestamps(type: :utc_datetime_usec)
    end

    create unique_index(:federation_configs, [:singleton_key])
  end
end
