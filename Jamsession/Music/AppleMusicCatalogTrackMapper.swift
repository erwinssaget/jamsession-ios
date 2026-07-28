import MusicKit

nonisolated enum AppleMusicCatalogTrackMapper {
    static func map(_ song: Song) -> CatalogTrackSelection {
        CatalogTrackSelection(
            id: TrackID(song.id.rawValue),
            title: song.title,
            artistName: song.artistName,
            isExplicit: song.contentRating == .explicit
        )
    }
}
