# frozen_string_literal: true

module Media
  # Creating, getting, and deleting media attached to responses.
  class ObjectsController < ApplicationController
    include Storage

    before_action :set_media_object, only: %i[show destroy]
    skip_authorization_check

    def self.media_type(class_name)
      case class_name
      when "Media::Audio" then "audios"
      when "Media::Video" then "videos"
      when "Media::Image" then "images"
      else raise "A valid media class must be specified"
      end
    end

    # - Replace objects_controller#show with direct attachment logic in answers_helper
    # - Set @media_object.item's filename in the db? or somehow dynamically? (See objects_controller#media_filename)
    # - answers_helper#thumb_path needs some sort of refactor?
    # - file_upload_spec "uploading files" should pass now

    # TODO: Remove? OR Simply send_attachment?
    # Normally in the page, <a href=some_url> rails_rep_url(media_object)...
    # read docs again, am I missing some simplicity?
    def show
      style = params[:style] || "original"
      @answer = @media_object.answer
      @response = @answer.try(:response)
      disposition = params[:dl] == "1" ? "attachment" : "inline"

      authorize!(:show, @response) if @response

      # send_attachment(@media_object.item,
      #   style: style, disposition: disposition, filename: media_filename)

      attachment = @media_object.item
      params = {style: style, disposition: disposition, filename: media_filename}

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

    def create
      media = media_class(params[:type]).new
      media.item.attach(params[:upload])
      # answer_id can be blank because creation is asynchronous and
      # will be assigned when the response is submitted
      media.answer = Answer.find(params[:answer_id]) if params[:answer_id]

      if media.save
        # Json keys match hidden input names that contain the key in dropzone form.
        # See ELMO.Views.FileUploaderView for more info.
        render(json: {media_object_id: media.id}, status: :created)
      else
        # Currently there is only one type of validation failure: incorrect type.
        # The default paperclip error messages are heinous, which is why we're doing this.
        msg = I18n.t("errors.file_upload.invalid_format")
        render(json: {errors: [msg]}, status: :unprocessable_entity)
      end
    end

    def destroy
      @media_object.destroy
      render(body: nil, status: :no_content)
    end

    private

    def set_media_object
      @media_object = Media::Object.find(params[:id])
    end

    def media_object_params
      params.require(:media_object).permit(:answer_id, :annotation)
    end

    # TODO: Use this somehow? Or remove, was only used by #show
    def media_filename
      extension = File.extname(@media_object.item.filename.to_s)
      if @response && @answer
        "elmo-#{@response.shortcode}-#{@answer.id}#{extension}"
      else
        "elmo-unsaved_response-#{@media_object.id}#{extension}"
      end
    end

    def media_class(type)
      case type
      when "audios" then Media::Audio
      when "videos" then Media::Video
      when "images" then Media::Image
      else raise "A valid media type must be specified"
      end
    end
  end
end
