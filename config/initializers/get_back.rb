BACKUP_DIR = Rails.env.production? ? Rails.root.join("../../shared/backups") : "#{Rails.root}/db/backups/"

GetBack::Engine.config.paths["db/migrate"].expanded.each do |expanded_path|
  Rails.application.config.paths["db/migrate"] << expanded_path
end

