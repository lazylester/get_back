require 'spec_helper'

describe ".save_to_file" do
  before do
    ActiveRecord::Base.connection.execute("DROP TABLE IF EXISTS test")
    ActiveRecord::Base.connection.create_table :test do |t|
      t.column :foo, :string
    end
    ApplicationDatabase.new.save_to_file( Rails.root.join('tmp','sql_test.sql') )
  end

  it "file should contain database contents" do
    expect(File.read( Rails.root.join('tmp','sql_test.sql'))).to match "PostgreSQL database dump complete"
  end

  after do
    File.delete(Rails.root.join('tmp','sql_test.sql'))
  end
end

describe ".restore_from_file" do
  before do
    sql =<<-SQL
      drop table if exists test;
      create table test (  foo varchar(255) );
      insert into test (foo) values ( 'bar');
    SQL
    file = Rails.root.join('tmp','sql_test.sql')
    File.write(file, sql)
    ApplicationDatabase.new.restore_from_file(DbBackup.new(:filename => file))
  end

  it "should restore the database contents from file" do
    expect(ActiveRecord::Base.connection.execute("select * from test").first["foo"]).to eq 'bar'
  end

  after do
    File.delete(Rails.root.join('tmp','sql_test.sql'))
  end
end

describe ".restore_from_compressed_file" do
  before do
    sql =<<-SQL
      drop table if exists test;
      create table test ( foo varchar(255));
      insert into test (foo) values ( 'bar');
    SQL
    ActiveRecord::Base.connection.execute(sql)
    file = Rails.root.join('tmp','pg_dump_sql_test.sql')
    ApplicationDatabase.new.save_compressed_to_file(File.new(file,'w') )
    ActiveRecord::Base.connection.execute("drop table test;")
    ApplicationDatabase.new.restore_from_compressed_file(DbBackup.new(:filename => file.to_s))
  end

  it "should restore the database contents from file" do
    expect(ActiveRecord::Base.connection.execute("select * from test").first["foo"]).to eq 'bar'
  end

  after do
    ['pg_dump_sql_test.sql'].each do |filename|
      file = Rails.root.join('tmp',filename)
      File.delete(file) if File.exists? file
    end
  end
end
