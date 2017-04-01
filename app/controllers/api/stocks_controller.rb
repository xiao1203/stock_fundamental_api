class Api::StocksController < Api::ApplicationController
  before_action :check_params
  before_action :set_kabu_tec_values

  @detail_cache_key = nil
  @financial_statement_cache_key = nil
  @auto_trace_judgment_cache_key = nil

  def detail
    render json: Rails.cache.fetch(@detail_cache_key)
  end

  def financial_statement
    render json: Rails.cache.fetch(@financial_statement_cache_key)
  end

  def auto_trace_judgment
    render json: Rails.cache.fetch(@auto_trace_judgment_cache_key)
  end

  private

  def check_params
    render json: { status: :bad_request } if params[:stock_code].nil?
  end

  #
  def set_kabu_tec_values
    @detail_cache_key = "kabu_tec_detail_#{Time.now.strftime("%Y%m%d")}_#{params[:stock_code]}"
    @financial_statement_cache_key = "kabu_tec_financial_statement_#{Time.now.strftime("%Y%m%d")}_#{params[:stock_code]}"
    @auto_trace_judgment_cache_key = "kabu_tec_auto_trace_judgment_#{Time.now.strftime("%Y%m%d")}_#{params[:stock_code]}"

    if Rails.cache.fetch(@detail_cache_key).present? &&
        Rails.cache.fetch(@financial_statement_cache_key).present? &&
        Rails.cache.fetch(@auto_trace_judgment_cache_key).present?
      # キャッシュに全てのデータ格納を格納済みなのでスキップ
      return
    end

    scraper = StockFundamentalScraper::Scraper.new(
        stock_code: params[:stock_code],
        kabu_tec: true,
        rakuten_sec: false,
        kabu_tan: false,
        kabu_sensor: false
    )

    Rails.cache.fetch(@detail_cache_key) do
      scraper.kabu_tec_stock_info
    end

    Rails.cache.fetch(@financial_statement_cache_key) do
      scraper.kabu_tec_financial_statement
    end

    Rails.cache.fetch(@auto_trace_judgment_cache_key) do
      scraper.kabu_tec_auto_trace_judgment
    end
  end
end