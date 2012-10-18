class AddFieldsToEvents < ActiveRecord::Migration
	def up
		add_column :events, :submission_format, :string
		add_column :events, :submission_length, :integer
		add_column :events, :max_number_participants, :integer
		add_column :events, :off_the_record, :string
		add_column :events, :supporting_materials, :text
		add_column :events, :specific_conditions_to_meet, :text
		add_column :events, :submission_level, :string
		add_column :events, :target_audience, :string
	end

	def down
		remove_column :events, :target_audience
		remove_column :events, :submission_level
		remove_column :events, :specific_conditions_to_meet
		remove_column :events, :supporting_materials
		remove_column :events, :off_the_record
		remove_column :events, :max_number_participants
		remove_column :events, :submission_length
		remove_column :events, :submission_format
	end
end
