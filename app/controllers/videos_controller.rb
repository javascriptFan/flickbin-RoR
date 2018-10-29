class VideosController < ApplicationController
  before_action :authenticate_user!, only: [:new, :create, :destroy]

  def new
    @video = current_user.videos.build
  end

  def create
    @video = current_user.videos.build(create_params)

    if @video.save
      redirect_to new_video_path, notice: 'Your video has been shared!'
    elsif @video.errors.messages[:invalid_url].present?
      @invalid_video_url = true
      render :new
    else
      @existing_video = Video.includes(:tag)
                             .where(tag_id: create_params[:tag_id], url: create_params[:url])
                             .first
      render :new
    end
  end

  def show
    @video = Video.friendly.find(params[:video_slug])
    @video_owner = @video.user
    @tag = @video.tag
    comments = @video.comments
                     .roots
                     .includes(:commentator)
                     .order(created_at: :desc)
                     .limit(6)

    @comments_tree = comments.map { |comment| comment.subtree(to_depth: 1).arrange }

    if current_user.present?
      @vote = Vote.find_by(voter_id: current_user.id, video_id: @video.id)
    end
  end

  def destroy
    video = current_user.videos.find_by_slug(params[:video_slug])

    if video.present?
      video.update_attribute(:removed, true)
    else
      render js: "alert('Video with slug - \"#{params[:video_slug]}\" not found')"
    end
  end

  private

  def create_params
    params.fetch(:video, {}).permit(:url, :tag_name, :tag_id)
  end
end
