# frozen_string_literal: true

# Controller for the Snapshot resource.
class SnapshotsController < ApplicationController
  def index
    base_scope = Snapshot.includes(:card_pool)
    snapshots = SnapshotResource.all(params, base_scope)

    respond_with(snapshots)
  end

  def show
    base_scope = Snapshot.includes(:card_pool)
    snapshot = SnapshotResource.find(params, base_scope)
    respond_with(snapshot)
  end
end
