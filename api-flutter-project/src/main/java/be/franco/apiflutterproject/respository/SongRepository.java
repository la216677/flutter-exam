package be.franco.apiflutterproject.respository;

import be.franco.apiflutterproject.entity.Song;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface SongRepository extends JpaRepository<Song,Long> {


    Optional<Song> findByName(String fileName);
}
