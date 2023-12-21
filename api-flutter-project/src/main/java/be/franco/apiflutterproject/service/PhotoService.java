package be.franco.apiflutterproject.service;

import be.franco.apiflutterproject.entity.Photo;
import be.franco.apiflutterproject.respository.PhotoRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;
import java.io.IOException;
import java.nio.file.Path;

@Service
public class PhotoService {

    @Autowired
    private PhotoRepository photoRepository;

    public String uploadPhoto(MultipartFile photo) throws IOException {

        String uploadDir = "src/main/resources/static/photos/";

        File uploadDirectory = new File(uploadDir);
        if (!uploadDirectory.exists()) {
            uploadDirectory.mkdir();
        }

        Path uploadPath = Path.of(uploadDir + photo.getOriginalFilename());
        photo.transferTo(uploadPath);

        Photo photoOk = new Photo();
        photoOk.setPath(photo.getOriginalFilename());

        Photo savedPhoto = photoRepository.save(photoOk);
        return savedPhoto.getPath();
    }

    public Photo getPhoto(String path) {
        return photoRepository.findByPath(path);
    }

    public Photo getPhotoById(Long id) {
        return photoRepository.findById(id).get();
    }

    public Photo[] getAllPhotos() {
        return photoRepository.findAll().toArray(new Photo[0]);
    }

    public void deletePhoto(String path) {
        Photo photo = photoRepository.findByPath(path);
        File file = new File("src/main/resources/static/photos/" + photo.getPath());
        file.delete();
        photoRepository.delete(photo);
    }

    public Photo updatePhoto(Photo photo) {
        return photoRepository.save(photo);
    }
}
