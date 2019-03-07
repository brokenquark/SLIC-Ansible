require 'spec_helper'

describe TeamCityXmlPayload do
  let(:project) { create(:team_city_rest_project) }
  let(:payload) { TeamCityXmlPayload.new(project).tap{|p|p.status_content = content} }
  let(:payload_processor) { PayloadProcessor.new(project_status_updater: StatusUpdater.new) }

  describe '.process' do
    subject do
      payload_processor.process_payload(project: project, payload: payload)
      project
    end

    describe "project status" do
      context "when not currently building" do
        let(:content) {
          <<-XML.strip_heredoc
            <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
            <builds count="1">
              <build id="1" number="1" status="#{status}" webUrl="/1" startDate="#{5.minutes.ago}" />
            </builds>
          XML
        }

        context "when build was successful" do
          let(:status) { 'SUCCESS' }
          it { is_expected.to be_success }
        end

        context "when build had failed" do
          let(:status) { 'FAILURE' }
          it { is_expected.to be_failure }
        end

        context "with bad XML data" do
          let(:content) { "some non xml content" }
          it "should log erros" do
            expect(payload).to receive("log_error")
            payload.status_content = content
          end
        end
      end

      context "when building" do
        it "turns a green build red when in progress" do
          project.online = true
          project.save!

          content = <<-XML.strip_heredoc
            <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
            <builds count="1">
              <build id="1" number="1" status="SUCCESS" webUrl="/1" startDate="#{5.minutes.ago}" />
            </builds>
          XML
          payload = TeamCityXmlPayload.new(project)
          payload.status_content = content
          payload_processor.process_payload(project: project, payload: payload)

          expect(project.reload).to be_success

          content = <<-XML
            <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
            <builds count="1">
              <build id="3" number="3" status="FAILURE" webUrl="/1" running="true"/>
            </builds>
          XML
          payload.status_content = content
          payload_processor.process_payload(project: project, payload: payload)

          expect(project.reload).to be_failure
        end

        it "remains red when existing status is red" do
          project.online = true
          project.save!

          content = <<-XML.strip_heredoc
            <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
            <builds count="1">
              <build id="1" number="1" status="FAILURE" webUrl="/1" startDate="#{5.minutes.ago}" />
            </builds>
          XML
          payload = TeamCityXmlPayload.new(project)
          payload.status_content = content
          payload_processor.process_payload(project: project, payload: payload)

          expect(project.reload).to be_failure

          content = <<-XML
            <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
            <builds count="1">
              <build id="2" number="2" status="SUCCESS" webUrl="/1" running="true"/>
            </builds>
          XML
          payload.status_content = content
          payload_processor.process_payload(project: project, payload: payload)

          expect(project.reload).to be_failure
        end
      end
    end

    describe "building status" do
      let(:content) {
        <<-XML
            <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
            <builds count="1">
              <build id="1" number="1" status="FAILURE" webUrl="/1"
        #{project_is_running ? 'running="true"' : nil}
              />
            </builds>
        XML
      }

      context "with a valid response that the project is building" do
        let(:project_is_running) { true }
        it { is_expected.to be_building }
      end

      context "with a valid response that the project is not building" do
        let(:project_is_running) { false }
        it { is_expected.not_to be_building }
      end

      context "with an invalid response" do
        let(:content) { "<foo><bar>baz</bar></foo>" }
        it { is_expected.not_to be_building }
      end
    end
  end

  describe "unknown status" do
    it "remains green when existing status is green" do
      project.online = true
      project.save!
      content = <<-XML.strip_heredoc
            <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
            <builds count="1">
              <build id="1" number="1" status="SUCCESS" webUrl="/1" startDate="#{5.minutes.ago}" />
            </builds>
      XML
      payload = TeamCityXmlPayload.new(project)
      payload.status_content = content
      payload_processor.process_payload(project: project, payload: payload)

      expect(project.reload).to be_success
      statuses = project.statuses

      content = <<-XML
            <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
            <builds count="1">
              <build id="2" number="2" status="UNKNOWN" webUrl="/2" />
            </builds>
      XML
      payload = TeamCityXmlPayload.new(project)
      payload.status_content = content
      payload_processor.process_payload(project: project, payload: payload)

      expect(project.reload).to be_success
      expect(project.statuses).to eq(statuses)
    end
  end
end
