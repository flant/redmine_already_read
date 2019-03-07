require_dependency 'issues_controller'

class IssuesController < ApplicationController
  alias :already_read_find_issues :find_issues
  alias :already_read_authorize :authorize

  after_action :issue_read, only: [:show]

  skip_before_filter :authorize, only: [:bulk_set_read]
  before_filter :already_read_find_issues, only: [:bulk_set_read]
  before_filter :already_read_authorize, only: [:bulk_set_read]

  def bulk_set_read
    if params[:set_read]
      User.current.already_read_issues << @issues.reject{|issue| issue.already_read?}
    elsif params[:set_unread]
      AlreadyRead.destroy_all(issue_id: params[:ids], user_id: User.current.id)
    end
    redirect_back_or_default({controller: 'issues', action: 'index', project_id: @project})
  end

  private
  # 既読フラグを付ける
  def issue_read
    if User.current.logged? && @issue && !@issue.already_read?
      User.current.already_read_issues << @issue
    end
  end
end
