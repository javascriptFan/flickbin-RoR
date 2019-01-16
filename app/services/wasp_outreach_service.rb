class WaspOutreachService
  MAX_TOP_1_VIDEO_UPVOTES = 20

  def initialize(video_id)
    @video = Video.find(video_id)
    @dummy_user_ids = User.where(role: 'dummy').pluck(:id)
  end

  def call
    top_1_video = Video.active.tagged.where(tag_id: @video.tag_id).order(rank: :asc).first
    if top_1_video.present? && top_1_video.positive_votes_amount > MAX_TOP_1_VIDEO_UPVOTES
      Video.active.tagged.where(tag_id: @video.tag_id).order(rank: :asc).limit(3).update_all(untagged: true)
    end

    dummy_votes_handler
    votes_amount = rand(20..30)
    videos = Video.active.tagged.where(tag_id: @video.tag_id).order(rank: :asc).to_a
    reordered_videos = videos.insert(2, videos.delete_at(videos.index(@video)))
    reordered_videos.each_with_index do |video, index|
      break if votes_amount < 1

      case index
      when 0
        existing_video_handler(video, votes_amount)
      when 1
        votes_amount = rand(15..20)
        existing_video_handler(video, votes_amount)
        votes_amount -= 1
      when 2
        outreach_video_handler(votes_amount)
        votes_amount -= 2
      else
        existing_video_handler(video, votes_amount)
        votes_amount -= 2
      end
    end
  end

  private

  def dummy_votes_handler
    dummy_votes = Vote.joins(:tag, :voter).where(users: { role: 'dummy' }, tags: { id: @video.tag_id }).distinct
    dummy_votes.each do |vote|
      vote.video.decrement!(:positive_votes_amount)
      vote.video.user.decrement!(:rank)
      vote.destroy
    end
  end

  def existing_video_handler(video, votes_amount)
    video_owner = video.user
    voter_ids = @dummy_user_ids.sample(votes_amount)

    voter_ids.each do |voter_id|
      video.votes.create!(voter_id: voter_id, value: 1)
      video.increment!(:positive_votes_amount)
      video_owner.increment!(:rank)
    end
  end

  def outreach_video_handler(votes_amount)
    video_owner = @video.user
    voter_ids = @dummy_user_ids.sample(votes_amount)

    voter_ids.each do |voter_id|
      @video.votes.create!(voter_id: voter_id, value: 1)
      @video.increment!(:positive_votes_amount)
      video_owner.increment!(:rank)
    end
  end
end