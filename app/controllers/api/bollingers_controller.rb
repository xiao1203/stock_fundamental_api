class Api::BollingersController < Api::ApplicationController
  before_action :set_params

  def show
    json_value = Rails.cache.fetch("bollinger_#{Time.now.strftime("%Y%m%d")}_#{@type}_#{@range}") do
      scraper = StockFundamentalScraper::Scraper.new(
          stock_code: nil,
          kabu_tec: false,
          rakuten_sec: false,
          kabu_tan: false,
          kabu_sensor: true
      )

      if @type == "buy" && @range == "10"
        # ボリンジャー10日買いシグナル
        scraper.kabu_sensor_bollinger_ten_buy
      elsif @type == "buy" && @range == "25"
        # ボリンジャー25日買いシグナル
        scraper.kabu_sensor_bollinger_twentyfive_buy
      elsif @type == "sell" && @range == "10"
        # ボリンジャー10日売りシグナル
        scraper.kabu_sensor_bollinger_ten_sell
      elsif @type == "sell" && @range == "25"
        # ボリンジャー25日売りシグナル
        scraper.kabu_sensor_bollinger_twentyfive_sell
      end
    end

    render json: json_value
  end

  private

  def set_params
    set_type
    set_range
  end

  def set_type
    @type = "buy" # デフォルトは「買い」
    if params[:type].present? && ["buy", "sell"].include?(params[:type])
      @type = params[:type]
    end
  end

  def set_range
    @range = "10" # デフォルトは10
    if params[:range].present? && ["10", "25"].include?(params[:range])
      @range = params[:range]
    end
  end
end
