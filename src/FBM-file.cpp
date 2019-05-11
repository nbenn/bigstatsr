/******************************************************************************/

#include <fstream>
#include <stdexcept>
#include <bigstatsr/types.h>
#include <sys/stat.h>
#include <unistd.h>

#define ERROR_POS "Dimensions should be at least 1."

/******************************************************************************/

template <typename T>
void createFile(std::string fileName,
                std::size_t nrow,
                std::size_t ncol) {

  try {
    std::filebuf fbuf;
    fbuf.open(fileName.c_str(), std::ios_base::out | std::ios_base::binary);
    fbuf.pubseekpos(nrow * ncol * sizeof(T) - 1); fbuf.sputc(0);
    fbuf.close();
  } catch(std::exception& ex) {
    throw std::runtime_error("Problem creating the backing file.");
  }

}

#define CREATE_FILE(TYPE) return createFile<TYPE>(fileName, nrow, ncol);

// [[Rcpp::export]]
void createFile(std::string fileName,
                std::size_t nrow,
                std::size_t ncol,
                int type) {

  myassert(nrow > 0, ERROR_POS);
  myassert(ncol > 0, ERROR_POS);

  DISPATCH_TYPE(CREATE_FILE)
}

/******************************************************************************/

template <typename T>
void resizeFile(std::string fileName,
                std::size_t nrow,
                std::size_t ncol) {

  if(truncate(fileName.c_str(), nrow * ncol * sizeof(T)) != 0) {
    throw std::runtime_error("Problem resizing the backing file.");
  }
}

#define RESIZE_FILE(TYPE) return resizeFile<TYPE>(fileName, nrow, ncol);

// [[Rcpp::export]]
void resizeFile(std::string fileName,
                std::size_t nrow,
                std::size_t ncol,
                int type) {

  myassert(nrow > 0, ERROR_POS);
  myassert(ncol > 0, ERROR_POS);

  DISPATCH_TYPE(RESIZE_FILE)
}

/******************************************************************************/

// [[Rcpp::export]]
size_t getFileDu(const std::string& filename) {

  struct stat st;

  if(stat(filename.c_str(), &st) != 0) {
    throw std::runtime_error("Problem determining backing file disk usage.");
  }

  return st.st_blksize * st.st_blocks;   
}
