package be.franco.apiflutterproject.service;

import be.franco.apiflutterproject.entity.Photo;
import be.franco.apiflutterproject.entity.Song;
import be.franco.apiflutterproject.respository.ImageRepository;
import be.franco.apiflutterproject.respository.SongRepository;
import be.franco.apiflutterproject.util.ImageUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.NoSuchElementException;
import java.util.Optional;
import java.util.UUID;

@Service
public class SongService {
    @Autowired
    private SongRepository repository;

    @Autowired
    ImageRepository imageRepository;

    public Long uploadSong(MultipartFile file) throws IOException {
        String originalFileName = file.getOriginalFilename();
        String extension = originalFileName.substring(originalFileName.lastIndexOf("."));

        String randomName = UUID.randomUUID().toString() + extension;

        Song songData = repository.save(Song.builder()
                .name(randomName)
                .type(file.getContentType())
                .songData(ImageUtils.compressImage(file.getBytes())).build());
        if (songData != null) {
            return songData.getId();
        }
        return null;
    }

    public byte[] downloadSong(String fileName){
        Optional<Song> dbSongData = repository.findByName(fileName);
        if (dbSongData.isPresent()) {
            byte[] songs = ImageUtils.decompressImage(dbSongData.get().getSongData());
            return songs;
        } else {
            throw new NoSuchElementException("Aucune chanson trouvée avec le nom de fichier : " + fileName);
        }
    }



    // associate song with photo
    public void associateSongWithPhoto(Long songId, Long photoId){
        Optional<Song> dbSongData = repository.findById(songId);
        Optional<Photo> dbPhotoData = imageRepository.findById(photoId);
        dbPhotoData.get().setSong(dbSongData.get());
        imageRepository.save(dbPhotoData.get());
    }

    // delete
    public void deleteSong(Long id){
        repository.deleteById(id);
    }
}
