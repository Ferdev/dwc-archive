class DarwinCore
  class Generator
    class EmlXml

      def initialize(data, path)
        @data = data
        @path = path
        @write = 'w:utf-8'
      end

      def create
        eml_uri =  'eml://ecoinformatics.org/eml-2.1.1' + 
          ' http://rs.gbif.org/schema/eml-gbif-profile/1.0.1/eml.xsd'
        builder = Nokogiri::XML::Builder.new do |xml|
          xml.eml(packageId:      "%s/%s" % [@data[:id], timestamp],
            system:               @data[:system] || 'http://globalnames.org',
            :'xml:lang' =>         'en',
            :'xmlns:eml' =>        'eml://ecoinformatics.org/eml-2.1.1',
            :'xmlns:md' =>         'eml://ecoinformatics.org/methods-2.1.1',
            :'xmlns:proj' =>       'eml://ecoinformatics.org/project-2.1.1',
            :'xmlns:d' =>          'eml://ecoinformatics.org/dataset-2.1.1',
            :'xmlns:res' =>        'eml://ecoinformatics.org/resource-2.1.1',
            :'xmlns:dc' =>         'http://purl.org/dc/terms/',
            :'xmlns:xsi' =>        'http://www.w3.org/2001/XMLSchema-instance',
            :'xsi:schemaLocation' => 'eml_uri')  do
            xml.dataset(id: @data[:id]) do
              xml.title(@data[:title])
              xml.license(@data[:license])
              contacts = []
              @data[:authors].each_with_index do |a, i|
                creator_id = i + 1
                contacts << creator_id
                xml.creator(id: creator_id, scope: 'document') do
                  xml.individualName do
                    xml.givenName(a[:first_name])
                    xml.surName(a[:last_name])
                  end
                  xml.organizationName(a[:organization]) if a[:organization]
                  xml.positionName(a[:position]) if a[:position]
                  xml.onlineUrl(a[:url]) if a[:url]
                  xml.electronicMailAddress(a[:email])
                end
              end
              @data[:metadata_providers].each_with_index do |a, i|
                xml.metadataProvider do
                  xml.individualName do
                    xml.givenName(a[:first_name])
                    xml.surName(a[:last_name])
                  end
                  xml.organizationName(a[:organization]) if a[:organization]
                  xml.positionName(a[:position]) if a[:position]
                  xml.onlineUrl(a[:url]) if a[:url]
                  xml.electronicMailAddress(a[:email])
                end
              end if @data[:metadata_providers]
              xml.pubDate(Time.now.to_s)
              xml.abstract() do
                xml.para(@data[:abstract])
              end
              contacts.each do |contact|
                xml.contact { xml.references(contact) }
              end
            end
            xml.additionalMetadata do
              xml.metadata do
                xml.citation(@data[:citation])
                xml.resourceLogoUrl(@data[:logo_url]) if @data[:logo_url]
              end
            end
            xml.parent.namespace = xml.parent.namespace_definitions.first
          end
        end
        data = builder.to_xml
        f = open(File.join(@path, 'eml.xml'), @write)
        f.write(data)
        f.close
      end

      private
      def timestamp
        t = Time.now.getutc.to_a[0..5].reverse
        t[0..2].join('-') + '::' + t[-3..-1].join(':')
      end
    end
  end
end
