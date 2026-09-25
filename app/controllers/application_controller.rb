class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  # Every page requires a signed-in user; Devise's own controllers skip this for sign in/up.
  before_action :authenticate_user!

  private
    # Land on the sign-in page (not root) so the "Signed out" notice isn't lost to the
    # root -> sign-in redirect.
    def after_sign_out_path_for(_resource_or_scope)
      new_user_session_path
    end
end
