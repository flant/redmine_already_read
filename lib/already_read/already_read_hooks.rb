module RedmineAlreadyRead
  class Hooks < Redmine::Hook::ViewListener

    render_on :view_issues_context_menu_end, partial: 'already_read/update_context'
    render_on :view_issues_edit_notes_bottom, partial: 'already_read/without_reads_reset'

    def view_layouts_base_html_head(context = {})
        stylesheet_link_tag 'already_read.css', plugin: 'redmine_already_read'
    end

  end
end
