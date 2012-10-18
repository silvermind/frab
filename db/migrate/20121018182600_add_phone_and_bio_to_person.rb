class AddPhoneAndBioToPerson < ActiveRecord::Migration
	def up
		add_column :people, :previous_performances, :text
	end

	def down
		remove_column :people, :previous_performances
	end
end
