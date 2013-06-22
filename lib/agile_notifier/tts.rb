require 'uri'
require 'open-uri'

module AgileNotifier
  class TTS
    @@temp_file = File.dirname(__FILE__) + '/temp_tts'

    class << self
      def speak(text)
        speak_via('osx_speech', text)
      end

      def speak_via(service, text)
        call_service(service, text)
      end

      def call_service(service, text)
        Service.send(service.intern, text)
      end

      def replace_punctuation_by_space(text)
        text.gsub(/[[:punct:]](\s+)*/, ' ').gsub(/\s$/, '')
      end

      def encode_www_form(text)
        URI.encode_www_form('' => text)[1..-1]
      end

      def encode_www_form_and_remove_punctuation(text)
        encode_www_form(replace_punctuation_by_space(text))
      end

      def download_file(url, file = @@temp_file)
        open(url) do |remote_file|
          data = remote_file.read
          File.open(file, 'wb') do |local_file|
            local_file.write(data)
          end
        end
      end

      def remove_file(file = @@temp_file)
        File.delete(file)
      end
    end

    class Service
      class << self
        def osx_speech(text)
          fork { exec "say #{text}"}
        end

        def tts_api(text)
          url = 'http://tts-api.com/tts.mp3?q='
          url + encode_www_form_and_remove_punctuation(text)
        end

        def mary_tts(text)
          url = 'http://mary.dfki.de:59125/'
          text = encode_www_form_and_remove_punctuation(text)
          locale = 'de'
          audio_format = 'WAVE_FILE'
          url + "process?INPUT_TEXT=#{text}&INPUT_TYPE=TEXT&OUTPUT_TYPE=AUDIO&LOCALE=#{locale}&AUDIO=#{audio_format}"
        end
      end
    end

    private_class_method :new, :call_service, :replace_punctuation_by_space, :encode_www_form, :encode_www_form_and_remove_punctuation, :download_file, :remove_file
  end
end