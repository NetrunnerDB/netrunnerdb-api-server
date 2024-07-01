# frozen_string_literal: true

# Controller for the Snapshot resource.
class SnapshotsController < ApplicationController
  def index
    snapshots = SnapshotResource.all(params)

    respond_with(snapshots)
  end

  def show
    snapshot = SnapshotResource.find(params)
    respond_with(snapshot)
  end
end
