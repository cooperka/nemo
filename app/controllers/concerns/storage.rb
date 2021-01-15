# frozen_string_literal: true

# Provides method for sending file to user via
# direct download or redirect
module Storage
  extend ActiveSupport::Concern

  # TODO remove, only used 2 places that are also being removed
  def send_attachment(attachment, params = {})
    local = Rails.configuration.active_storage.service == :local
    style = params.delete(:style)

    if params[:disposition] == "inline"
      # 100px container, doubled to 200 to support retina screens.
      attachment = attachment.variant(resize_to_limit: [200, 200]).processed if style == "thumb"

      # What a mess, there must be a better way to handle local/cloud original/variant...
      url = if local
              attachment.respond_to?(:variation) ? rails_representation_url(attachment) : rails_blob_path(attachment)
            else
              attachment.service_url
            end
      return redirect_to(url)
    end

    default_params = {filename: attachment.filename.to_s,
                      content_type: attachment.content_type,
                      disposition: "attachment"}
    # TODO: Verify this actually streams, not delays.
    #   From Tom:
    #
    # # Stream from controller to download
    # response.headers["Content-Type"] = @model.image.content_type
    # response.headers["Content-Disposition"] = "attachment; #{@model.image.filename.parameters}"
    # @model.image.download do |chunk|
    #   response.stream.write(chunk)
    # end
    send_data(attachment.download, default_params.merge(params))
  end
end
