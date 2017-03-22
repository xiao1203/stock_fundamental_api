class Api::StocksController < Api::ApplicationController
  before_action :check_params
  before_action :set_kabu_tec_values

  def detail
    render json: Rails.cache.fetch("kabu_tec_detail_#{Time.now.strftime("%Y%m%d")}_#{params[:stock_code]}")
  end

  def financial_statement
    render json: Rails.cache.fetch("kabu_tec_financial_statement_#{Time.now.strftime("%Y%m%d")}_#{params[:stock_code]}")
  end

  def auto_trace_judgment
    render json: Rails.cache.fetch("kabu_tec_auto_trace_judgment_#{Time.now.strftime("%Y%m%d")}_#{params[:stock_code]}")
  end

  private

  def check_params
    render json: { status: :bad_request } if params[:stock_code].nil?
  end

  #
  def set_kabu_tec_values
    if Rails.cache.fetch("kabu_tec_detail_#{Time.now.strftime("%Y%m%d")}_#{params[:stock_code]}").nil? ||
        Rails.cache.fetch("kabu_tec_financial_statement_#{Time.now.strftime("%Y%m%d")}_#{params[:stock_code]}").nil? ||
        Rails.cache.fetch("kabu_tec_auto_trace_judgment_#{Time.now.strftime("%Y%m%d")}_#{params[:stock_code]}").nil?
    end

    scraper = StockFundamentalScraper::Scraper.new(
        stock_code: params[:stock_code],
        kabu_tec: true,
        rakuten_sec: false,
        kabu_tan: false,
        kabu_sensor: false
    )

    Rails.cache.fetch("kabu_tec_detail_#{Time.now.strftime("%Y%m%d")}_#{params[:stock_code]}") do
      scraper.kabu_tec_stock_info
    end

    Rails.cache.fetch("kabu_tec_financial_statement_#{Time.now.strftime("%Y%m%d")}_#{params[:stock_code]}") do
      scraper.kabu_tec_financial_statement
    end

    Rails.cache.fetch("kabu_tec_auto_trace_judgment_#{Time.now.strftime("%Y%m%d")}_#{params[:stock_code]}") do
      scraper.kabu_tec_auto_trace_judgment
    end
  end
end