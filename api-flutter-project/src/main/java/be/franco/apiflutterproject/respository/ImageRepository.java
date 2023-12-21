package be.franco.apiflutterproject.respository;

import be.franco.apiflutterproject.entity.Photo;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface ImageRepository extends JpaRepository<Photo,Long> {


    Optional<Photo> findByName(String fileName);
}
