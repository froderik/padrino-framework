COUCHPOTATO = (<<-COUCHPOTATO) unless defined?(COUCHPOTATO)
case Padrino.env
  when :development then db_name = '!NAME!_development'
  when :production  then db_name = '!NAME!_production'
  when :test        then db_name = '!NAME!_test'
end

CouchPotato::Config.database_name = db_name
# or CouchPotato::Config.database_name = http://<host>:<port>/db_name
# or CouchPotato::Config.database_name = http://<username>:<password>@<host>:<port>/db_name

# language for design documents - defaulting to :javascript
# CouchPotato::Config.default_language = :erlang

# views in own design documents - defaulting to false
# CouchPotato::Config.split_design_documents_per_view = true
COUCHPOTATO

def setup_orm
  require_dependencies 'couch_potato'
  create_file("config/database.rb", COUCHPOTATO.gsub(/!NAME!/, @app_name.underscore))
end

POTATO_MODEL = (<<-MODEL) unless defined?(POTATO_MODEL)
class !NAME!
  include CouchPotato::Persistence
  # property <name>, :type => String, :default => 'Fredrik' # type and default optional
  !FIELDS!
end
MODEL

# options => { :fields => ["title:string", "body:string"], :app => 'app' }
def create_model_file(name, options={})
  model_path = destination_root(options[:app], 'models', "#{name.to_s.underscore}.rb")
  field_tuples = options[:fields].map { |value| value.split(":") }
  column_declarations = field_tuples.map { |field, kind| 
    if kind
      "property :#{field}, :type => #{kind.capitalize}" 
    else
      "property :#{field}" 
    end
  }.join("\n  ")
  model_contents = POTATO_MODEL.gsub(/!NAME!/, name.to_s.underscore.camelize)
  model_contents.gsub!(/!FIELDS!/, column_declarations)
  create_file(model_path, model_contents)
end

def create_model_migration(filename, name, fields)
  # NO MIGRATION NEEDED
end

def create_migration_file(migration_name, name, columns)
  # NO MIGRATION NEEDED
end
