class DeleteEventJob < ActiveJob::Base
  queue_as :high

  def perform(source)
    ActiveRecord::Base.connection_pool.with_connection do
      # only delete references if they are not linked via other sources
      work_ids = Relation.where(source_id: source.id).select(:work_id, :related_work_id).group(:work_id, :related_work_id).having("count(*) = 1").pluck(:work_id)
      Work.where(id: work_ids).destroy_all
      source.relations.destroy_all

      # reset metrics to zero and delete all
      source.retrieval_statuses.update_all(total: 0, pdf: 0, html: 0, readers: 0, comments: 0, likes: 0)
      source.months.destroy_all
      source.days.destroy_all
      source.write_cache
    end
  end
end
