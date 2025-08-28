# frozen_string_literal: true

class AddVisitsToProjects < ActiveRecord::Migration[7.2]
	def change
		add_column :projects, :visits, :integer, default: 0, null: false unless column_exists?(:projects, :visits)
	end
end
