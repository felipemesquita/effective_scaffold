class <%= controller_class_name %>Controller < ApplicationController
  # GET /<%= table_name %>
  # GET /<%= table_name %>.xml
  def index
    @<%= table_name %> = <%= class_name %>.paginate :page => params[:page], :order => 'created_at DESC',
      :conditions => <%= controller_prefix.empty? ? '"1=1"' : "{" + controller_prefix.collect {|x| ":#{x.singularize}_id => params[:#{x.singularize}_id]"}.join(', ') + "}" %>

    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @<%= table_name %>.to_xml }
    end
  end

  # GET /<%= table_name %>/1
  # GET /<%= table_name %>/1.xml
  def show
    @<%= file_name %> = <%= class_name %>.find(params[:id])
<% controller_prefix.each do |prefix| -%>
    return render :nothing => true, :status => 401 unless @<%= file_name %>.<%= prefix.singularize %>_id.to_s == params[:<%= prefix.singularize %>_id]
<% end -%>

    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @<%= file_name %>.to_xml }
    end
  end

  # GET /<%= table_name %>/new
  def new
    @<%= file_name %> = <%= class_name %>.new
<% controller_prefix.each do |prefix| -%>
    @<%= file_name %>.<%= prefix.singularize %>_id = params[:<%= prefix.singularize %>_id]
<% end -%>
  end

  # GET /<%= table_name %>/1/edit
  def edit
    @<%= file_name %> = <%= class_name %>.find(params[:id])
<% controller_prefix.each do |prefix| -%>
    return render :nothing => true, :status => 401 unless @<%= file_name %>.<%= prefix.singularize %>_id.to_s == params[:<%= prefix.singularize %>_id]
<% end -%>
  end

  # POST /<%= table_name %>
  # POST /<%= table_name %>.xml
  def create
    @<%= file_name %> = <%= class_name %>.new(params[:<%= file_name %>])
<% controller_prefix.each do |prefix| -%>
    @<%= file_name %>.<%= prefix.singularize %>_id = params[:<%= prefix.singularize %>_id]
<% end -%>

    respond_to do |format|
      if @<%= file_name %>.save
        flash[:notice] = '<%= class_name %> was successfully created.'
        format.html { redirect_to <%= route_prefix + file_name %>_url(<%= param_prefix %>@<%= file_name %>) }
        format.xml  { head :created, :location => <%= route_prefix + file_name %>_url(<%= param_prefix %>@<%= file_name %>) }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @<%= file_name %>.errors.to_xml }
      end
    end
  end

  # PUT /<%= table_name %>/1
  # PUT /<%= table_name %>/1.xml
  def update
    @<%= file_name %> = <%= class_name %>.find(params[:id])
<% controller_prefix.each do |prefix| -%>
    return render :nothing => true, :status => 401 unless @<%= file_name %>.<%= prefix.singularize %>_id.to_s == params[:<%= prefix.singularize %>_id]
<% end -%>

    respond_to do |format|
      if @<%= file_name %>.update_attributes(params[:<%= file_name %>])
        flash[:notice] = '<%= class_name %> was successfully updated.'
        format.html { redirect_to <%= route_prefix + file_name %>_url(<%= param_prefix %>@<%= file_name %>) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @<%= file_name %>.errors.to_xml }
      end
    end
  end

  # DELETE /<%= table_name %>/1
  # DELETE /<%= table_name %>/1.xml
  def destroy
    @<%= file_name %> = <%= class_name %>.find(params[:id])
<% controller_prefix.each do |prefix| -%>
    return render :nothing => true, :status => 401 unless @<%= file_name %>.<%= prefix.singularize %>_id.to_s == params[:<%= prefix.singularize %>_id]
<% end -%>
    @<%= file_name %>.destroy

    respond_to do |format|
      format.html { redirect_to <%= route_prefix + table_name %>_url(<%= param_prefix_only %>) }
      format.xml  { head :ok }
    end
  end
end
