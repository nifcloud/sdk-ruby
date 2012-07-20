module NIFTY
  class Response
    # ニフティクラウドAPIのレスポンス解析クラス
    #
    #  @option options [String] :xml           解析対象のXML
    #  @option options [Hash] :parse_options   xml-simpleの解析オプション
    #  @return [Hash] レスポンスXML解析結果
    #
    def self.parse(options = {})
      options = {
        :xml => "",
        :parse_options => { 'forcearray' => ['item', 'member'], 'suppressempty' => nil, 'keeproot' => false }
      }.merge(options)

      return response = XmlSimple.xml_in(options[:xml], options[:parse_options])
    end
  end
end 

