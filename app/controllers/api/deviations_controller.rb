class Api::DeviationsController < Api::ApplicationController
  before_action :set_params

  def show
    json_value = Rails.cache.fetch("deviations_#{Time.now.strftime("%Y%m%d")}_#{@type}") do
      scraper = StockFundamentalScraper::Scraper.new(
          stock_code: nil,
          kabu_tec: false,
          rakuten_sec: false,
          kabu_tan: false,
          kabu_sensor: true
      )

      if @type == "buy"
        # RSI 買いシグナル
        scraper.kabu_sensor_kairi_buy
      elsif @type == "sell"
        # RSI 売りシグナル
        scraper.kabu_sensor_kairi_sell
      end
    end

    render json: json_value
  end

  private

  def set_params
    set_type
  end

  def set_type
    @type = "buy" # デフォルトは「買い」
    if params[:type].present? && ["buy", "sell"].include?(params[:type])
      @type = params[:type]
    end
  end
end
