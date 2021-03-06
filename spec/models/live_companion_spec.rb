require 'rails_helper'

RSpec.describe LiveCompanion, type: :model do
  let!(:live_companion) { create(:live_companion) }

  context "バリデーション" do
    it "有効な状態であること" do
      expect(live_companion).to be_valid
    end

    it "アーティスト名がなければ無効な状態であること" do
      live_companion = build(:live_companion, artist_name: nil)
      live_companion.valid?
      expect(live_companion.errors[:artist_name]).to include("を入力してください")
    end

    it "ライブ名がなければ無効な状態であること" do
      live_companion = build(:live_companion, live_name: nil)
      live_companion.valid?
      expect(live_companion.errors[:live_name]).to include("を入力してください")
    end

    it "日程がなければ無効な状態であること" do
      live_companion = build(:live_companion, schedule: nil)
      live_companion.valid?
      expect(live_companion.errors[:schedule]).to include("を入力してください")
    end

    it "会場がなければ無効な状態であること" do
      live_companion = build(:live_companion, live_venue: nil)
      live_companion.valid?
      expect(live_companion.errors[:live_venue]).to include("を入力してください")
    end

    it "アーティスト名が30文字以内であること" do
      live_companion = build(:live_companion, artist_name: "あ" * 31)
      live_companion.valid?
      expect(live_companion.errors[:artist_name]).to include("は30文字以内で入力してください")
    end

    it "ライブ名が50文字以内であること" do
      live_companion = build(:live_companion, live_name: "あ" * 51)
      live_companion.valid?
      expect(live_companion.errors[:live_name]).to include("は50文字以内で入力してください")
    end

    it "ライブメモが140文字以内であること" do
      live_companion = build(:live_companion, live_memo: "あ" * 141)
      live_companion.valid?
      expect(live_companion.errors[:live_memo]).to include("は140文字以内で入力してください")
    end

    it "ユーザーIDがなければ無効な状態であること" do
      live_companion = build(:live_companion, user_id: nil)
      live_companion.valid?
      expect(live_companion.errors[:user_id]).to include("を入力してください")
    end
  end

  context "並び順" do
    it "最も最近の投稿が最初の投稿になっていること" do
      expect(live_companion).to eq LiveCompanion.first
    end
  end
end
