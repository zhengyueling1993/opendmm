module OpenDMM
  module Maker
    module AnnaAndHanako
      include Maker

      module Site
        include HTTParty
        base_uri "anna-and-hanako.jp"

        def self.item(name)
          case name
          when /(ANND)-?(\d{3})/i
            get("/works/#{$1.downcase}/#{$1.downcase}#{$2}.html")
          end
        end
      end

      module Parser
        def self.parse(content)
          page_uri = content.request.last_uri
          html = Nokogiri::HTML(Utils.force_utf8(content))
          specs = Utils.hash_by_split(html.xpath('//*[@id="pake-bottom-box_r"]/dl/p').map(&:text))
          return {
            actresses:     specs["出演者"].split("/"),
            code:          specs["品番"],
            cover_image:   URI.join(page_uri, html.xpath('//*[@id="pake-bottom-box"]/dl/a').first["href"]).to_s,
            description:   html.xpath('//*[@id="txt-bottom-box"]').text,
            directors:     specs["監督"].split("/"),
            movie_length:  ChronicDuration.parse(specs["収録時間"]),
            page:          page_uri.to_s,
            release_date:  Date.parse(specs["発売日"]),
            sample_images: html.xpath('//*[@id="mein-sanpuru-sam"]/a').map { |a| URI.join(page_uri, a["href"]).to_s },
            title:         html.xpath('//*[@id="mein-left-new-release-box"]/div/div/h5').text,
          }
        end
      end
    end
  end
end
