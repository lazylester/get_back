class ApplicationDatabase::MysqlAdapter
  attr_accessor :db_config

  def initialize(db_config)
    @db_config = db_config
  end

  def save_compressed_to_file(file)
    raise "Not yet implemented"
  end

  def zipped_contents
    raise "Not yet implemented"
  end

  def extract_contents
    raise "Not yet implemented"
  end

  def save_to_file(file)
    raise "Not yet implemented"
  end

  def restore_from_file(backfile)
    raise "Not yet implemented"
  end

  def restore_from_compressed_file(backfile)
    raise "Not yet implemented"
  end

private
  def dump_contents
  end

  def dump_to_file(file)
  end

  def sql_restore_from_file(filename)
  end

  def sql_restore_from_compressed_file(filename)
  end

  def psql
  end

  def pg_dump
  end

  def sql_restore
  end
end
