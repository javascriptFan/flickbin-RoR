ActiveAdmin.register Battle do
  permit_params :tag_id, :final_date, :first_member_id, :second_member_id, :status

  controller do
    def scoped_collection
      super.includes(:tag, :first_member, :second_member)
    end
  end

  index do
    selectable_column
    id_column
    column :tag
    column :first_member_id do |battle|
      battle.first_member.name
    end
    column :second_member_id do |battle|
      battle.second_member.name
    end
    column :final_date
    column :status do |battle|
      case battle.status
      when 'live'
        status_tag(battle.status, class: "orange abc")
      when 'finished'
        status_tag(battle.status, :yes, class: "abc")
      end
    end
    column :created_at
    column :updated_at
    actions
  end

  form do |f|
    f.semantic_errors
    f.inputs do
      f.input :tag
      f.input :first_member_id, as: :search_select, url: admin_battle_members_path,
                    fields: [:name], display_name: :name, minimum_input_length: 2,
                    order_by: 'name_asc'
      f.input :second_member_id, as: :search_select, url: admin_battle_members_path,
                    fields: [:name], display_name: :name, minimum_input_length: 2,
                    order_by: 'name_asc'
      f.input :final_date, as: :date_time_picker,
                           input_html: { style: 'width: 100px;' }
      f.input :status, as: :select, collection: Battle::STATUSES
    end
    f.actions
  end

  filter :tag
end
