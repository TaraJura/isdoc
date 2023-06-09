# frozen_string_literal: true

class PublicStorageController < ApplicationController
  def index
    @instances = Instance.where(public: true).order(created_at: :desc)
  end

  def file
    @instance = Instance.new()
    @instance.public = true
    @instance.user_id = User.first.id
    @instance.files.attach(params[:file])
    @instance.save
  end
end
