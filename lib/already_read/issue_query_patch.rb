require_dependency 'query'
require_dependency 'issue_query'

IssueQuery.add_available_column(QueryColumn.new(:already_read))
IssueQuery.add_available_column(QueryColumn.new(:already_read_date))

module AlreadyReadIssueQueryPatch
  def self.included(base) # :nodoc:
    base.send(:include, InstanceMethods) # obj.method

    base.class_eval do
      alias_method_chain :available_filters, :already_read
    end
  end

  module InstanceMethods # obj.method
    # 既読フィルタを追加
    def available_filters_with_already_read
      return @available_filters if @available_filters
      available_filters_without_already_read

      if !has_filter?('already_read')
        add_available_filter('already_read',
          type: :list,
          order: 20,
          values: @available_filters['author_id'].values,
          name: l(:field_already_read)
        )
      end

      return @available_filters
    end

    def sql_for_already_read_field(field, operator, value)
      db_table = AlreadyRead.table_name
      # <<自分>>を変換
      if value.include?('me') && value.delete('me')
        if User.current.logged?
          value.push(User.current.id.to_s)
        elsif value.empty?
          value.push("0")
        end
      end
      oldest_created_on = Principal.where(id: value).minimum(:created_on)

      op = ('=' == operator)? 'IN' : 'NOT IN'

      sql = "#{Issue.table_name}.id #{op} (SELECT #{db_table}.issue_id FROM #{db_table} WHERE " + sql_for_field(field, '=', value, db_table, 'user_id') + ") AND #{Issue.table_name}.updated_on > '#{oldest_created_on}'"

      return sql
    end
  end
end

IssueQuery.send(:include, AlreadyReadIssueQueryPatch)
