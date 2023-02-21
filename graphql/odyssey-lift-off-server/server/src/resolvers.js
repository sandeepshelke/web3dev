const resolvers = {
    Query: {
        // returns an array of Tracks that will be used to
        // populate the home page grid of client
        tracksForHome: (_, __, {dataSources}) => {
            return dataSources.trackAPI.getTracksForHome();
        },
        track: (_, {id}, {dataSources}) => {
            return dataSources.trackAPI.getTrack(id);
        }
    },

    Mutation: {
        // increament a track's numberOfViews property
        incrementTrackViews: async (_, {id}, {dataSources}) => {
            try {
                const track = await dataSources.trackAPI.incrementTrackViews(id);
                return {
                    code: 200,
                    success: true,
                    message: `successfully increamented number of views for the track ${id}`,
                    track,
                };
            }
            catch(err) {
                return {
                    code: err.extensions.response.status,
                    success: false,
                    message: err.extensions.response.body,
                    track: null,
                };
            }
        }
    },

    Track: {
        author: ({authorId}, _, {dataSources}) => {
            return dataSources.trackAPI.getAuthor(authorId);
        },
        modules: ({id}, _, {dataSources}) => {
            return dataSources.trackAPI.getTrackModules(id);
        },
    }
};

module.exports = resolvers;
