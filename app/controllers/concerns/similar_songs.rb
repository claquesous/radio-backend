module SimilarSongs
  DEFAULT_WEIGHTS = { sound: 1.0, creators: 1.0, genre_era: 1.0 }.freeze
  MAX_LIMIT = 100

  private

    def render_similar(song, stream: nil)
      @song = song
      @results = Recommender.similar(song, **similar_options(default_limit: 25), stream:)
      render "songs/similar"
    end

    # Weights come from ?sound=&creators=&genre_era=; any facet given replaces the
    # defaults entirely, so ?sound=1 means "sound only". The seeds' own artists are
    # left out unless ?same_artist=1, and ?per_artist= (default 1) caps how many
    # songs any one artist contributes.
    def similar_options(default_limit:)
      given = params.permit(*Recommender::FACETS).to_h.symbolize_keys
      @weights = given.empty? ? DEFAULT_WEIGHTS : given
      {
        weights: @weights,
        limit: (params[:limit] || default_limit).to_i.clamp(1, MAX_LIMIT),
        same_artist: ActiveModel::Type::Boolean.new.cast(params[:same_artist]) || false,
        per_artist: (params[:per_artist] || 1).to_i.clamp(1, MAX_LIMIT)
      }
    end
end
