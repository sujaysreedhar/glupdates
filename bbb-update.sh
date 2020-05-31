#!/bin/bash

# sysinfo_page - A script to produce an HTML file
echo "starting"
echo "updating footer:"

cat > app/views/shared/_footer.html.erb << _EOF_
<footer class="footer pt-3">
  <p class="text-center mb-1"><%= t("footer.powered_by", href: link_to("Space Shaala Pvt Ltd", "https://spaceshaala.com/", target: "_blank")).html_safe %> &copy;  SSERD 2020</p>
</footer>

<%= render "shared/components/cookie_warning" %>
_EOF_
echo "footer updated"
echo "updating header"

cat > app/views/shared/_header.html.erb << _EOF_
<div class="header py-4">
  <div class="container">
    <div class="d-flex">
      <%= link_to (current_user ? home_page : root_path), class: "header-brand" do %>
        <% begin %>
          <%= image_tag(logo_image, class: "header-brand-img", alt:"") %>
        <% rescue %>
          <%= t("administrator.site_settings.branding.invalid") %>
        <% end %>
      <% end %>

      <div class="d-flex ml-auto">
        <% if current_user %>

          <%= link_to home_page, class: "px-3 mx-1 mt-1 header-nav #{active_home}" do %>
            <i class="fas fa-home pr-1 "></i><span class="d-none d-sm-inline-block"><%= t("header.dropdown.home") %></span>
          <% end %>

          <% if current_user.role.get_permission("can_create_rooms") && !current_user.has_role?(:super_admin) %>
            <% all_rec_page = params[:controller] == "users" && params[:action] == "recordings" ? "active" : "" %>
            <%= link_to get_user_recordings_path(current_user), class: "px-3 mx-1 mt-1 header-nav #{all_rec_page}" do %>
              <i class="fas fa-video pr-1"></i><span class="d-none d-sm-inline-block"><%= t("header.all_recordings") %></span>
            <% end %>
          <% end %>

          <div class="dropdown">
            <a href="#" class="nav-link pr-0" data-toggle="dropdown">
              <% if current_user.image.blank? || !valid_url?(current_user.image) %>
                <span class="avatar"><%= current_user.name.first %></span>
              <% else %>
                <span id="user-avatar" class="avatar d-none"><%= current_user.name.first %></span>
                <%= image_tag(current_user.image, id: "user-image", class: "avatar") %>
              <% end %>
              <span class="ml-2 d-none d-lg-block">
                <span class="text-default username"><%= current_user.name %></span>
              </span>
            </a>
            <div class="dropdown-menu dropdown-menu-right dropdown-menu-arrow" x-placement="bottom-end">
              <%= link_to edit_user_path(current_user), class: "dropdown-item"  do %>
                <i class="dropdown-icon fas fa-id-card mr-3"></i><%= t("header.dropdown.settings") %>
              <% end %>
              <% highest_role = current_user.role %>
              <% if highest_role.get_permission("can_manage_users") || highest_role.name == "super_admin" %>
                <%= link_to admins_path, class: "dropdown-item" do %>
                  <i class="dropdown-icon fas fa-user-tie mr-3"></i><%= t("header.dropdown.account_settings") %>
                <% end %>
              <% elsif highest_role.get_permission("can_manage_rooms_recordings")%>
                <%= link_to admin_rooms_path, class: "dropdown-item" do %>
                  <i class="dropdown-icon fas fa-user-tie mr-3"></i><%= t("header.dropdown.account_settings") %>
                <% end %>
              <% elsif highest_role.get_permission("can_edit_site_settings") %>
                <%= link_to admin_site_settings_path, class: "dropdown-item" do %>
                  <i class="dropdown-icon fas fa-user-tie mr-3"></i><%= t("header.dropdown.account_settings") %>
                <% end %>
              <% elsif highest_role.get_permission("can_edit_roles")%>
                <%= link_to admin_roles_path, class: "dropdown-item" do %>
                  <i class="dropdown-icon fas fa-user-tie mr-3"></i><%= t("header.dropdown.account_settings") %>
                <% end %>
              <% end %>
              <div class="dropdown-divider"></div>
              <% if Rails.configuration.help_url.present? %>
                <a class="dropdown-item" href="<%= Rails.configuration.help_url %>" target="_blank" rel="noopener">
                  <i class="dropdown-icon far fa-question-circle"></i> <%= t("header.dropdown.help") %>
                </a>
              <% end %>
              <% if Rails.configuration.report_issue_url.present? %>
                <a class="dropdown-item" href="<%= Rails.configuration.report_issue_url %>" target="_blank" rel="noopener">
                  <i class="dropdown-icon fas fa-exclamation mr-3"></i><%= t("errors.internal.report") %>
                </a>
              <% end %>
              <%= button_to logout_path, class: "dropdown-item" do %>
                <i class="dropdown-icon fas fa-sign-out-alt"></i> <%= t("header.dropdown.signout") %>
              <% end %>
            </div>
          </div>
        <% else %>
          <% allow_greenlight_accounts = allow_greenlight_accounts? %>
          <% if allow_greenlight_accounts %>
            <%= link_to t("login"), signin_path, :class => "btn btn-outline-primary mx-2 sign-in-button" %>
          <% elsif Rails.configuration.loadbalanced_configuration %>
            <%= link_to t("login"), omniauth_login_url(:bn_launcher), :class => "btn btn-outline-primary mx-2 sign-in-button" %>
          <% else %>
            <%= link_to t("login"), signin_path, :class => "btn btn-outline-primary mx-2 sign-in-button" %>
          <% end %>

        <% end %>
      </div>
    </div>
  </div>
</div>
_EOF_
echo "header updated"
echo "updating application"

cat > app/views/layouts/application.html.erb << _EOF_
<!DOCTYPE html>
<html>
  <head>
    <% if Rails.configuration.google_analytics %>
      <!-- Global site tag (gtag.js) - Google Analytics -->
      <script async src="<%= google_analytics_url %>"></script>
      <script>
        window.dataLayer = window.dataLayer || [];
        function gtag(){dataLayer.push(arguments);}
        gtag('js', new Date());

        gtag('config', "<%= ENV["GOOGLE_ANALYTICS_TRACKING_ID"] %>");
      </script>
    <% end %>

    <title>AstroSpaceCamp Online E-Learning Portal</title>
    <meta property="og:title" content="AstroSpaceCamp Online E-Learning Portal" />
    <meta property="og:type" content="website" />
    <meta property="og:description" content="AstroSpaceCamp powered by SSERD and SpaceShaala" />
    <meta property="og:url" content="<%= request.base_url %>" />
    <meta property="og:image" content="<%= logo_image %>" />
    <meta name="viewport" content= "width=device-width, user-scalable=no">
    <%= csrf_meta_tags %>

    <!-- Global javascript variables and helpers. -->
    <script type="text/javascript">
      window.GreenLight = {};
      window.GreenLight.WEBSOCKET_HOST = "<%= ENV['WEBSOCKET_HOST'] %>"
      window.GreenLight.RELATIVE_ROOT = "<%= relative_root %>"
    </script>

    <%= stylesheet_link_tag    'application', media: 'all', 'data-turbolinks-track': 'reload' %>
    <%= javascript_include_tag 'application', 'data-turbolinks-track': 'reload' %>

    <!-- Primary color styling -->
    <%= stylesheet_link_tag themes_primary_path %>

    <script type="text/javascript">
      // Include the correct translated strings for Javascript
      window.I18n = <%= current_translations.to_json.html_safe %>
      window.I18nFallback = <%= fallback_translations.to_json.html_safe %>
    </script>
  </head>

  <body class="app-background" data-controller="<%= params[:controller] %>" data-action="<%= params[:action] %>" data-relative-root="<%= Rails.configuration.relative_url_root || "/" %>">
    <%= render "shared/header" %>

    <div class="wrapper">
      <% if bigbluebutton_endpoint_default? %>
        <div class="alert alert-icon alert-danger text-center mb-0">
          <div class="flash alert d-inline">
            <i class="fas fa-exclamation-triangle"></i>
            <p class="d-inline"><%= t("test_install",
              href: link_to(t("docs").downcase, "http://docs.bigbluebutton.org/install/greenlight-v2.html#2-install-greenlight", target: "_blank", rel: "noopener")
            ).html_safe %>
          </div>
        </div>
      <% end %>

      <% unless Rails.configuration.banner_message.blank? %>
        <div class="alert alert-icon alert-danger text-center mb-0">
          <div class="flash alert d-inline">
            <p class="d-inline"><%= Rails.configuration.banner_message %></p>
          </div>
        </div>
      <% end %>

      <%= render 'shared/flash_messages' unless flash.empty? %>

      <%= yield %>
    </div>

    <%= render "shared/footer" %>
  </body>
</html>
_EOF_

echo "updated"


echo "updating index"

cat > app/views/main/index.html.erb << _EOF_
<div class="background">
  <div class="container pt-9 pb-8">
    <div class="row">
      <div class="col-md-12 col-sm-12 text-center">
        <h1 id="main-text" class="display-4 mb-4">Online Astro Space Camp</h1>
        <p class="lead offset-lg-2 col-lg-8 col-sm-12 ">Online Astro Space camp is brought to you by SSERD & Space Shaala.</p>
        <%= link_to "https://sserd.org/onlineclass", target: "_blank" do %>
          <h4>Register Now<i class="far fa-play-circle ml-1"></i></h4>
        <% end %>
      </div>

    </div>
  </div>
</div>

<%= render "main/components/features" %>
_EOF_

echo "updated"


echo "updating application"

cat > app/views/main/components/_features.html.erb << _EOF_

_EOF_

echo "updated"
