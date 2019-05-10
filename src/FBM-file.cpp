/******************************************************************************/

#include <fstream>
#include <stdexcept>
#include <bigstatsr/types.h>
#include <filesystem>

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

  try {

    std::filesystem::path file = fileName.c_str();

    if (std::filesystem::exists(file)) {
      std::filesystem::resize_file(file, nrow * ncol * sizeof(T));
    }

  } catch(std::exception& ex) {
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
