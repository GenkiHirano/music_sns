require 'rails_helper'

RSpec.describe "LiveCompanions", type: :system do
  let!(:user) { create(:user) }
  let!(:other_user) { create(:user) }
  let!(:live_companion) { create(:live_companion, user: user) }
  let!(:comment) { create(:comment, user_id: user.id, live_companion: live_companion) }

  describe "ライブ同行者募集投稿ページ" do
    before do
      login_for_system(user)
      visit new_live_companion_path
    end

    context "ページレイアウト" do
      it "「一緒にライブに行く人を募集する」の文字列が存在すること" do
        expect(page).to have_content '一緒にライブに行く人を募集する'
      end

      it "正しいタイトルが表示されること" do
        expect(page).to have_title full_title('一緒にライブに行く人を募集する')
      end

      it "入力部分に適切なラベルが表示されること" do
        expect(page).to have_content 'アーティスト名'
        expect(page).to have_content 'ライブ名'
        expect(page).to have_content 'ライブメモ'
      end
    end

    context "ライブ同行者募集投稿処理" do
      it "有効な情報でライブ同行者募集投稿を行うと「ライブ同行者の募集が完了しました！」のフラッシュが表示されること" do
        fill_in "live_companion[artist_name]", with: "米津玄師"
        fill_in "live_companion[live_name]",   with: "米津玄師 2020 TOUR / HYPE"
        fill_in "live_companion[live_memo]",   with: "誰か、米津玄師さんの一緒にライブ行きませんか...？"
        click_button "登録する"
        expect(page).to have_content "ライブ同行者の募集が完了しました！"
      end

      it "無効な情報でライブ同行者募集投稿を行うと登録失敗のフラッシュが表示されること" do
        fill_in "live_companion[artist_name]", with: ""
        fill_in "live_companion[live_name]",   with: "米津玄師 2020 TOUR / HYPE"
        fill_in "live_companion[live_memo]",   with: "誰か、米津玄師さんの一緒にライブ行きませんか...？"
        click_button "登録する"
        expect(page).to have_content "アーティスト名を入力してください"
      end
    end
  end

  describe "投稿詳細ページ" do
    context "ページレイアウト" do
      before do
        login_for_system(user)
        visit live_companion_path(live_companion)
      end

      it "正しいタイトルが表示されること" do
        expect(page).to have_title full_title("#{live_companion.artist_name}")
      end

      it "ライブ情報が表示されること" do
        expect(page).to have_content live_companion.artist_name
        expect(page).to have_content live_companion.live_name
        expect(page).to have_content live_companion.live_memo
      end
    end

    context "投稿の削除", js: true do
      it "削除成功のフラッシュが表示されること" do
        login_for_system(user)
        visit live_companion_path(live_companion)
        within find('.change-live_companion') do
          click_on '削除'
        end
        page.driver.browser.switch_to.alert.accept
        expect(page).to have_content '投稿が削除されました'
      end
    end

    context "コメントの登録＆削除" do
      it "自分の投稿に対するコメントの登録＆削除が正常に完了すること" do
        login_for_system(user)
        visit live_companion_path(live_companion)
        fill_in "comment_content", with: "誰か一緒に行きましょう！"
        click_button "コメント"
        within find("#comment-#{Comment.last.id}") do
          expect(page).to have_selector 'span', text: user.name
          expect(page).to have_selector 'span', text: '誰か一緒に行きましょう！'
        end
        expect(page).to have_content "コメントを追加しました！"
        click_link "削除", href: comment_path(Comment.last)
        expect(page).not_to have_selector 'span', text: '誰か一緒に行きましょう！'
        expect(page).to have_content "コメントを削除しました"
      end

      it "別ユーザーの投稿コメントには削除リンクが無いこと" do
        login_for_system(other_user)
        visit live_companion_path(live_companion)
        within find("#comment-#{comment.id}") do
          expect(page).to have_selector 'span', text: user.name
          expect(page).to have_selector 'span', text: comment.content
          expect(page).not_to have_link '削除', href: live_companion_path(live_companion)
        end
      end
    end
  end

  describe "投稿編集ページ" do
    before do
      login_for_system(user)
      visit live_companion_path(live_companion)
      click_link "編集"
    end

    context "ページレイアウト" do
      it "正しいタイトルが表示されること" do
        expect(page).to have_title full_title('同行ライブ情報の編集')
      end

      it "入力部分に適切なラベルが表示されること" do
        expect(page).to have_content 'アーティスト名'
        expect(page).to have_content 'ライブ名'
        expect(page).to have_content 'ライブメモ'
      end

      context "投稿の削除処理", js: true do
        it "削除成功のフラッシュが表示されること" do
          click_on '削除'
          page.driver.browser.switch_to.alert.accept
          expect(page).to have_content '投稿が削除されました'
        end
      end
    end

    context "投稿の編集処理" do
      it "有効な更新" do
        fill_in "live_companion[artist_name]", with: "編集：米津玄師"
        fill_in "live_companion[live_name]",   with: "編集：米津玄師 2020 TOUR / HYPE"
        fill_in "live_companion[live_memo]",   with: "編集：誰か、米津玄師さんの一緒にライブ行きませんか...？"
        click_button "更新する"
        expect(page).to have_content "ライブ情報が更新されました！"
        expect(live_companion.reload.artist_name).to eq "編集：米津玄師"
        expect(live_companion.reload.live_name).to eq "編集：米津玄師 2020 TOUR / HYPE"
        expect(live_companion.reload.live_memo).to eq "編集：誰か、米津玄師さんの一緒にライブ行きませんか...？"
      end

      it "無効な更新" do
        fill_in "live_companion[artist_name]", with: ""
        click_button "更新する"
        expect(page).to have_content 'アーティスト名を入力してください'
        expect(live_companion.reload.artist_name).not_to eq ""
      end
    end
  end
end