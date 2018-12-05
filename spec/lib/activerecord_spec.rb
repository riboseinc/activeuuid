require "spec_helper"

describe Article do
  let!(:article) { Fabricate :article }
  let(:id) { article.id }
  let(:model) { Article }
  subject { model }

  context "model" do
    its(:all) { should == [article] }
    its(:first) { should == article }
  end

  context "existance" do
    subject { article }
    its(:id) { should be_a Integer }
  end

  context ".find" do
    specify { expect(model.find(id)).to eq(article) }
  end

  context ".where" do
    specify { expect(model.where(id: id).first).to eq(article) }
  end

  context "#destroy" do
    subject { article }
    its(:delete) { should be_truthy }
    its(:destroy) { should be_truthy }
  end

  context "#save" do
    subject { article }
    let(:array) { [1, 2, 3] }

    its(:save) { should be_truthy }

    context "when change array field" do
      before { article.some_array = array }
      its(:save) { should be_truthy }
    end
  end
end

describe UuidArticle do
  let!(:article) { Fabricate :uuid_article }
  let!(:id) { article.id }
  let(:model) { UuidArticle }
  subject { model }

  context "model" do
    its(:primary_key) { should == "id" }
    its(:all) { should == [article] }
    its(:first) { should == article }
  end

  context "existance" do
    subject { article }
    its(:id) { should be_a UUIDTools::UUID }
  end

  context "interpolation" do
    specify { model.where("id = :id", id: article.id) }
  end

  context "batch interpolation" do
    before { model.update_all(["title = CASE WHEN id = :id THEN 'Passed' ELSE 'Nothing' END", id: article.id]) }
    specify { expect(article.reload.title).to eq("Passed") }
  end

  context ".find" do
    specify { expect(model.find(article.id)).to eq(article) }
    specify { expect(model.find(id)).to eq(article) }
    specify { expect(model.find(id.to_s)).to eq(article) }
    specify { expect(model.find(id.raw)).to eq(article) }
  end

  context ".where" do
    specify { expect(model.where(id: article).first).to eq(article) }
    specify { expect(model.where(id: id).first).to eq(article) }
    specify { expect(model.where(id: id.to_s).first).to eq(article) }
    specify { expect(model.where(id: id.raw).first).to eq(article) }
  end

  context "#destroy" do
    subject { article }
    its(:delete) { should be_truthy }
    its(:destroy) { should be_truthy }
  end

  context "#reload" do
    subject { article }
    its(:'reload.id') { should == id }
    specify { expect(subject.reload(select: :another_uuid).id).to eq(id) }
  end

  context "columns" do
    %i[id another_uuid].each do |column|
      context column do
        subject { model.columns_hash[column.to_s] }
        its(:type) { should == :uuid }
      end
    end
  end

  context "typecasting" do
    let(:uuid) { UUIDTools::UUID.random_create }
    let(:string) { uuid.to_s }
    context "primary" do
      before { article.id = string }
      specify do
        expect(article.id).to eq(uuid)
        expect(article.id_before_type_cast).to eq(string)
      end
      specify do
        expect(article.id_before_type_cast).to eq(string)
        expect(article.id).to eq(uuid)
      end
    end

    context "non-primary" do
      before { article.another_uuid = string }
      specify do
        expect(article.another_uuid).to eq(uuid)
        expect(article.another_uuid_before_type_cast).to eq(string)
      end
      specify do
        expect(article.another_uuid_before_type_cast).to eq(string)
        expect(article.another_uuid).to eq(uuid)
      end
      specify do
        article.save
        article.reload
        expect(article.another_uuid_before_type_cast).to eq(string)
        expect(article.another_uuid).to eq(uuid)
      end
    end
  end
end

describe UuidArticleWithNaturalKey do
  let!(:article) { Fabricate :uuid_article_with_natural_key }
  let!(:id) { article.id }
  let!(:uuid) { UUIDTools::UUID.sha1_create(UUIDTools::UUID_OID_NAMESPACE, article.title) }
  subject { article }
  context "natural_key" do
    its(:id) { should == uuid }
  end
end

describe UuidArticleWithNamespace do
  let!(:article) { Fabricate :uuid_article_with_namespace }
  let!(:id) { article.id }
  let!(:namespace) { UuidArticleWithNamespace._uuid_namespace }
  let!(:uuid) { UUIDTools::UUID.sha1_create(namespace, article.title) }
  subject { article }
  context "natural_key_with_namespace" do
    its(:id) { should == uuid }
  end
end
