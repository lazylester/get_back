class ApplicationDatabase::PostgresAdapter
  attr_accessor :db_config

  def initialize(db_config)
    @db_config = db_config
  end

  def zipped_contents
    temp_file = Rails.root.join('tmp','pg_dump_temp_file.sql').to_s
    system("touch #{temp_file}")
    system("#{pg_dump} -w -Fc #{db_config['database']} > #{temp_file}")
    File.read(temp_file)
  end

  def save_compressed_to_file(file)
    # -Fc means "custom format" which is compressed by default
    system("#{pg_dump} -w -Fc #{db_config['database']} > #{file}")
    $?.exitstatus.zero?
  end

  def save_to_file(file)
    system("touch #{file}")
    system("#{pg_dump} -w -Fp --clean #{db_config['database']} > #{file}")
    $?.exitstatus.zero?
  end

  def restore_from_file(file)
    file = file.file.path
    `#{psql} #{db_config['database']} < #{file}`
    $?.exitstatus.zero?
  end

  def restore_from_compressed_file(file)
    file = file.file.path
    system("#{pg_restore} --clean --if-exists -d #{db_config['database']} #{file}")
    $?.exitstatus.zero?
  end

private
  # alternative access to db using --dbname=#{db_connection_uri}
  def db_connection_uri
    "postgresql://#{db_config['username']}:#{db_config['password']}@127.0.0.1:5432/#{db_config['database']}"
  end

  def psql
    `which psql`.strip
  end

  def pg_dump
    `which pg_dump`.strip
  end

  def pg_restore
    `which pg_restore`.strip
  end

end
