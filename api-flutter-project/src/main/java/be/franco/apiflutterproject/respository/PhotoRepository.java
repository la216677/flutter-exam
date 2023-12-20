package be.franco.apiflutterproject.respository;

import be.franco.apiflutterproject.entity.Photo;
import org.springframework.data.jpa.repository.JpaRepository;

public interface PhotoRepository extends JpaRepository<Photo, Long> {
    Photo findByPath (String path);
}
