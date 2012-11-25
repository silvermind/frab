class MakeAbstractRequired < ActiveRecord::Migration
	def up
		# Make sure no null value exist
		Person.update_all({:abstract => '-'}, {:abstract => nil})
		# Change the column to not allow null
		change_column :people, :abstract, :text, :null => false
	end

	def down
		change_column :people, :abstract, :text, :null => true
	end
end
