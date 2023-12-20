package be.franco.apiflutterproject.respository;

import be.franco.apiflutterproject.entity.Song;
import org.springframework.data.jpa.repository.JpaRepository;

public interface SongRepository extends JpaRepository<Song, Long> {
    Song findByPath (String path);
}