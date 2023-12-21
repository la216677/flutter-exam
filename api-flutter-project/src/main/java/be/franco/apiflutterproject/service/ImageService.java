package be.franco.apiflutterproject.service;

import be.franco.apiflutterproject.entity.Photo;
import be.franco.apiflutterproject.respository.ImageRepository;
import be.franco.apiflutterproject.util.ImageUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Service
public class ImageService {
    @Autowired
    private ImageRepository repository;



    public String uploadImage(MultipartFile file) throws IOException {
        String originalFileName = file.getOriginalFilename();
        String extension = originalFileName.substring(originalFileName.lastIndexOf("."));

        String randomName = UUID.randomUUID().toString() + extension;

        Photo imageData = repository.save(Photo.builder()
                .name(randomName)
                .type(file.getContentType())
                .imageData(ImageUtils.compressImage(file.getBytes())).build());
        if (imageData != null) {
            return "file uploaded successfully : " + randomName;
        }
        return null;
    }


    public byte[] downloadImage(String fileName){
        Optional<Photo> dbImageData = repository.findByName(fileName);
        byte[] images=ImageUtils.decompressImage(dbImageData.get().getImageData());
        return images;
    }

    // Get by id
    public byte[] downloadImage(Long id){
        Optional<Photo> dbImageData = repository.findById(id);
        byte[] images=ImageUtils.decompressImage(dbImageData.get().getImageData());
        return images;
    }

    // Get all
    public List<Photo> getAll(){
        List<Photo> allPhotos = new ArrayList<>();
        Iterable<Photo> allPhotosIterable = repository.findAll();

        for(Photo photo : allPhotosIterable){
            allPhotos.add(photo);
        }

        return allPhotos;
    }

    // get all ids
    public List<Long> getAllIds(){
        List<Long> allIds = new ArrayList<>();
        Iterable<Photo> allPhotos = repository.findAll();

        for(Photo photo : allPhotos){
            allIds.add(photo.getId());
        }

        return allIds;
    }

    public Photo getById(Long id){
        Optional<Photo> photo = repository.findById(id);
        return photo.get();
    }

    // Delete by id
    public void deleteById(Long id){
        repository.deleteById(id);
    }
}
