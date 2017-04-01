class Api::BooksController < Api::ApplicationController
  before_action :check_params
  before_action :set_rakuten_sec_values

  @pl_cache_key = nil
  @bs_cache_key = nil
  @cf_cache_key = nil

  def pl
    render json: Rails.cache.fetch(@pl_cache_key)
  end

  def bs
    render json: Rails.cache.fetch(@bs_cache_key)
  end

  def cf
    render json: Rails.cache.fetch(@cf_cache_key)
  end

  private

  def check_params
    render json: { status: :bad_request } if params[:stock_code].nil?
  end

  def set_rakuten_sec_values
    @pl_cache_key = "rakuten_sec_pl_#{Time.now.strftime("%Y%m%d")}_#{params[:stock_code]}"
    @bs_cache_key = "rakuten_sec_bs_#{Time.now.strftime("%Y%m%d")}_#{params[:stock_code]}"
    @cf_cache_key = "rakuten_sec_cf_#{Time.now.strftime("%Y%m%d")}_#{params[:stock_code]}"

    if Rails.cache.fetch(@pl_cache_key).present? &&
        Rails.cache.fetch(@bs_cache_key).present? &&
        Rails.cache.fetch(@cf_cache_key).present?
      # キャッシュに全てのデータ格納を格納済みなのでスキップ
      return
    end

    scraper = StockFundamentalScraper::Scraper.new(
        stock_code: params[:stock_code],
        kabu_tec: false,
        rakuten_sec: true,
        kabu_tan: false,
        kabu_sensor: false
    )

    Rails.cache.fetch(@pl_cache_key) do
      scraper.rakuten_sec_pl
    end

    Rails.cache.fetch(@bs_cache_key) do
      scraper.rakuten_sec_bs
    end

    Rails.cache.fetch(@cf_cache_key) do
      scraper.rakuten_sec_cf
    end
  end
end