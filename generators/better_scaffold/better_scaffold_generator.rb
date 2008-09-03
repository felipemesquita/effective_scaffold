class BetterScaffoldGenerator < Rails::Generator::NamedBase
  attr_reader   :controller_name, :controller_prefix,
                :controller_class_path,
                :controller_file_path,
                :controller_class_nesting,
                :controller_class_nesting_depth,
                :controller_class_name,
                :controller_singular_name,
                :controller_plural_name
  alias_method  :controller_file_name,  :controller_singular_name
  alias_method  :controller_table_name, :controller_plural_name

  def initialize(runtime_args, runtime_options = {})
    if not runtime_args.empty?
      @controller_prefix = runtime_args.first.split('/')
      runtime_args[0] = @controller_prefix.pop
    end
    super
    @controller_name = @name.pluralize

    base_name, @controller_class_path, @controller_file_path, @controller_class_nesting, @controller_class_nesting_depth = extract_modules(@controller_name)
    @controller_class_name_without_nesting, @controller_singular_name, @controller_plural_name = inflect_names(base_name)

    if @controller_class_nesting.empty?
      @controller_class_name = @controller_class_name_without_nesting
    else
      @controller_class_name = "#{@controller_class_nesting}::#{@controller_class_name_without_nesting}"
    end
  end
  
  def prefix_assigns
    @prefix_assigns ||= { 
      :route_prefix => @controller_prefix.empty? ? '' : (@controller_prefix.collect(&:singularize).join('_') + "_"),
      :param_prefix => @controller_prefix.empty? ? '' : (@controller_prefix.collect(&:singularize).collect {|x| "params[:#{x}_id]"}.join(', ') + ", "),
      :param_prefix_only => @controller_prefix.empty? ? '' : (@controller_prefix.collect(&:singularize).collect {|x| "params[:#{x}_id]"}.join(', ')),
      :controller_prefix => @controller_prefix,
    }
  end

  def manifest
    record do |m|
      # Check for class naming collisions.
      m.class_collisions(controller_class_path, "#{controller_class_name}Controller", "#{controller_class_name}Helper")
      m.class_collisions(class_path, "#{class_name}")

      # Controller, helper, views, and test directories.
      m.directory(File.join('app/models', class_path))
      m.directory(File.join('app/controllers', controller_class_path))
      m.directory(File.join('app/helpers', controller_class_path))
      m.directory(File.join('app/views', controller_class_path, controller_file_name))
      m.directory(File.join('app/views/layouts', controller_class_path))
      m.directory(File.join('test/functional', controller_class_path))
      m.directory(File.join('test/unit', class_path))

      for action in scaffold_views
        m.template(
          "view_#{action}.rhtml",
          File.join('app/views', controller_class_path, controller_file_name, "#{action}.rhtml"),
          :assigns => prefix_assigns
        )
      end

      # Layout and stylesheet.
      m.template('layout.rhtml', File.join('app/views/layouts', controller_class_path, "#{controller_file_name}.rhtml"))
      m.template('style.css', 'public/stylesheets/scaffold.css')

      m.template('model.rb', File.join('app/models', class_path, "#{file_name}.rb"))

      m.template(
        'controller.rb', File.join('app/controllers', controller_class_path, "#{controller_file_name}_controller.rb"),
        :assigns => prefix_assigns
      )

      m.template('functional_test.rb', File.join('test/functional', controller_class_path, "#{controller_file_name}_controller_test.rb"))
      m.template('helper.rb',          File.join('app/helpers',     controller_class_path, "#{controller_file_name}_helper.rb"))
      m.template('unit_test.rb',       File.join('test/unit',       class_path, "#{file_name}_test.rb"))
      m.template('fixtures.yml',       File.join('test/fixtures', "#{table_name}.yml"))

      unless options[:skip_migration]
        m.migration_template(
          'migration.rb', 'db/migrate', 
          :assigns => {
            :migration_name => "Create#{class_name.pluralize.gsub(/::/, '')}",
            :attributes     => attributes
          }, 
          :migration_file_name => "create_#{file_path.gsub(/\//, '_').pluralize}"
        )
      end

      route_string = ":#{controller_file_name}" + 
        "#{@controller_prefix.empty? ? '' : ', :path_prefix => "' + (@controller_prefix.collect {|x| "#{x.pluralize}/:#{x.singularize}_id"}.join('/')) + '"'}" +
        "#{@controller_prefix.empty? ? '' : ', :name_prefix => "' + (@controller_prefix.collect {|x| x.singularize}.join('_')) + '_"'}"
      def route_string.to_sym; to_s; end
      def route_string.inspect; to_s; end
      m.route_resources route_string
    end
  end

  protected
    # Override with your own usage banner.
    def banner
      "Usage: #{$0} better_scaffold ModelName [field:type, field:type]"
    end

    def scaffold_views
      %w[ index show new edit _form _summary ]
    end

    def model_name 
      class_name.demodulize
    end
end
