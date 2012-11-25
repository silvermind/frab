class PeopleAddAcqInOrgaField < ActiveRecord::Migration
  def up
	  add_column :people, :acq_in_orga, :text, :null => true
  end

  def down
	  remove_column :people, :acq_in_orga
  end
end
