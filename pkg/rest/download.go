package rest

import (
	"context"
	"net/http"
	"time"
)

type DownloadService service

type DownloadParameters struct {
	FileID        *int    `json:"file_id,omitempty"`
	FileName      *string `json:"file_name,omitempty"`
	ForceDownload *bool   `json:"force_download,omitempty"`
	InFPS         *int    `json:"in_fps,omitempty"`
	OutFPS        *int    `json:"out_fps,omitempty"`
	SubFormat     *string `json:"sub_format,omitempty"`
	Timeshift     *int    `json:"timeshift,omitempty"`
}

type Download struct {
	Link         *string    `json:"link,omitempty"`
	FileName     *string    `json:"file_name,omitempty"`
	Requests     *int       `json:"requests,omitempty"`
	Remaining    *int       `json:"remaining,omitempty"`
	Message      *string    `json:"message,omitempty"`
	ResetTime    *string    `json:"reset_time,omitempty"`
	ResetTimeUTC *time.Time `json:"reset_time_utc,omitempty"`
}

func (s *DownloadService) Download(ctx context.Context, p *DownloadParameters) (*Download, *http.Response, error) {
	u, err := s.client.NewURL("download", nil)
	if err != nil {
		return nil, nil, err
	}

	req, err := s.client.NewRequest("POST", u, &p)
	if err != nil {
		return nil, nil, err
	}

	var r *Download
	res, err := s.client.Do(ctx, req, &r)
	if err != nil {
		return nil, res, err
	}

	return r, res, nil
}
